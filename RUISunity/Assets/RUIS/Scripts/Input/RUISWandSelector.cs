/*****************************************************************************

Content    :   Implements selection behavior for RUISWands
Authors    :   Mikael Matveinen, Tuukka Takala
Copyright  :   Copyright 2013 Tuukka Takala, Mikael Matveinen. All Rights reserved.
Licensing  :   RUIS is distributed under the LGPL Version 3 license.

******************************************************************************/

using UnityEngine;
using System.Collections;

[System.Serializable]
[AddComponentMenu("RUIS/Input/RUISWandSelector")]
public class RUISWandSelector : MonoBehaviour {
    public enum SelectionRayType {
        HeadToWand,
        WandDirection
    };

    public SelectionRayType selectionRayType = SelectionRayType.WandDirection;
    private LineRenderer lineRenderer;
    public float selectionRayLength = 200;
    public float selectionRayStartDistance = 0.2f;
    private Vector3 selectionRayStart;
    private Vector3 selectionRayEnd;
	private Vector3 headToWandDirection;
    public Ray selectionRay { get; private set; }

    public Transform headTransform;

    public bool toggleSelection = false;
    public bool grabWhileButtonDown = true;

    private bool selectionButtonReleasedAfterSelection = false;

    public LayerMask ignoredLayers;


    public enum SelectionGrabType
    {
        SnapToWand,
        RelativeToWand,
        AlongSelectionRay, 
        DoNotGrab
    }

    public SelectionGrabType positionSelectionGrabType = SelectionGrabType.SnapToWand;
    public SelectionGrabType rotationSelectionGrabType = SelectionGrabType.SnapToWand;


    public int selectedGameObjectsLayer = 0;
    private int originalSelectedGameObjectLayer = -1;
    
    private RUISWand wand;
    private RUISSelectable selection;
    public RUISSelectable Selection
    {
        get
        {
            return selection;
        }
    }

    private RUISSelectable highlightedObject;
    public RUISSelectable HighlightedObject
    {
        get
        {
            return highlightedObject;
        }
    }

    public Vector3 angularVelocity
    {
        get
        {
            return wand.GetAngularVelocity();
        }
    }

    public void Awake()
    {
        wand = GetComponent<RUISWand>();

        if (!wand)
        {
            Debug.LogError(name + ": RUISWandSelector requires a RUISWand");
        }

        lineRenderer = GetComponent<LineRenderer>();
    }

    public void Start()
    {
        if (lineRenderer)
        {
            lineRenderer.SetVertexCount(2);
        }
    }

    public void Update()
    {
        GameObject selectionGameObject = CheckForSelection();
        if (!selection)
        {
            if (selectionGameObject)
            {
                RUISSelectable selectableObject = selectionGameObject.GetComponent<RUISSelectable>();
                //also search in parents if we didn't find RUISSelectable on this gameobject to allow for multi-piece collider hierarchies
                while (!selectableObject && selectionGameObject.transform.parent != null)
                {
                    selectionGameObject = selectionGameObject.transform.parent.gameObject;
                    selectableObject = selectionGameObject.GetComponent<RUISSelectable>();
                }

                if (selectableObject && !selectableObject.isSelected)
                {
                    if (selectableObject != highlightedObject)
                    {
                        if (highlightedObject != null) highlightedObject.OnSelectionHighlightEnd();

                        selectableObject.OnSelectionHighlight();
                        highlightedObject = selectableObject;
                    }

                    if ((!grabWhileButtonDown && wand.SelectionButtonWasPressed()) || (grabWhileButtonDown && wand.SelectionButtonIsDown()))
                    {
                        selection = selectableObject;

                        if (highlightedObject != null)
                        {
                            highlightedObject.OnSelectionHighlightEnd();
                            highlightedObject = null;
                        }


                        BeginSelection();

                        selectionButtonReleasedAfterSelection = false;
                    }
                }
            }

            if (!selectionGameObject || !selectionGameObject.GetComponent<RUISSelectable>())
            {
                if (highlightedObject != null)
                {
                    highlightedObject.OnSelectionHighlightEnd();
                    highlightedObject = null;
                }
            }
        } 
        else if (wand.SelectionButtonWasReleased()){
            if (!toggleSelection || 
                (toggleSelection && selectionButtonReleasedAfterSelection) ||
                !wand.IsSelectionButtonStandard())
            {
                EndSelection();

            }
            else
            {
                selectionButtonReleasedAfterSelection = true;
            }
        }
    }

    void LateUpdate()
    {
        UpdateLineRenderer();
    }

    private GameObject CheckForSelection()
    {
        switch (selectionRayType)
        {
            case SelectionRayType.HeadToWand:
                RaycastHit headToWandHit;
				headToWandDirection = transform.position - headTransform.position;
                selectionRay = new Ray(headTransform.position + selectionRayStartDistance*headToWandDirection, headToWandDirection);


                while(Physics.Raycast(selectionRay, out headToWandHit, selectionRayLength, ~ignoredLayers))
                {
                    selectionRayEnd = headToWandHit.point;
                    return headToWandHit.collider.gameObject;
                }
                break;
            case SelectionRayType.WandDirection:
                RaycastHit wandDirectionHit;
                selectionRay = new Ray(transform.position + selectionRayStartDistance*transform.forward, transform.forward);

                if (Physics.Raycast(selectionRay, out wandDirectionHit, selectionRayLength, ~ignoredLayers))
                {
                    selectionRayEnd = wandDirectionHit.point;
                    return wandDirectionHit.collider.gameObject;
                }
                else
                {
                    selectionRayEnd = transform.position + selectionRayLength * transform.forward;
                }
                break;
        }
        return null;
    }

    private void BeginSelection()
    {
        originalSelectedGameObjectLayer = selection.gameObject.layer;
        
        SetLayersRecursively(selection.gameObject, selectedGameObjectsLayer);

        selection.OnSelection(this);
    }

    private void EndSelection()
    {
        selection.OnSelectionEnd();

        RevertLayersRecursively(selection.gameObject);
        originalSelectedGameObjectLayer = -1;

        selection = null;
    }

    private void SetLayersRecursively(GameObject root, int layer)
    {
        if (root.layer == originalSelectedGameObjectLayer)
        {
            root.layer = layer;
        }

        foreach (Transform child in root.transform)
        {
            SetLayersRecursively(child.gameObject, layer);
        }
    }

    private void RevertLayersRecursively(GameObject root)
    {
        if (root.layer == selectedGameObjectsLayer)
        {
            root.layer = originalSelectedGameObjectLayer;
        }

        foreach(Transform child in root.transform){
            RevertLayersRecursively(child.gameObject);
        }
    }

    private void UpdateLineRenderer()
    {
        if(!lineRenderer) return;

        lineRenderer.enabled = selection == null && selectionRayType == SelectionRayType.WandDirection;

        lineRenderer.SetColors(wand.color, wand.color);

        lineRenderer.SetPosition(0, selectionRay.origin);// + selectionRayStartDistance * selectionRay.direction);
        lineRenderer.SetPosition(1, selectionRayEnd);
    }
}
