using UnityEngine;
using System.Collections;

public class ObjectScale : MonoBehaviour {

	private Vector3 initialScaling = new Vector3 (0, 0, 0);
	private Vector3 startDistance = new Vector3 (1, 1, 1);
	private Vector3 controller2StartLoc = new Vector3 (0, 0, 0);

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		RUISSelectable target = (RUISSelectable) this.GetComponent (typeof(RUISSelectable));
		GameObject wand1 = GameObject.Find ("MouseWand");
		RUISMouseWand mouseWand1Scripts = (RUISMouseWand) wand1.GetComponent(typeof(RUISMouseWand));
		GameObject wand2 = GameObject.Find ("MouseWand");

		if (mouseWand1Scripts.SelectionButtonWasPressed()) //TODO mahdollisesti kaks nappia pohjassa 
		{
			Vector3 controller1StartLoc = wand1.transform.position;
			controller2StartLoc = wand2.transform.position;
			controller2StartLoc = controller2StartLoc + new Vector3 (1, 1, 1);
			startDistance = controller1StartLoc - controller2StartLoc;
			initialScaling = this.transform.localScale;
		} 
		else if (target.isSelected && mouseWand1Scripts.SelectionButtonIsDown()) //TODO mahdollisesti kaks nappia pohjassa 
		{
			Vector3 endDistance = wand1.transform.position - controller2StartLoc;
			scaleUpdate(startDistance, endDistance);
		} 
		else if (target.isSelected && mouseWand1Scripts.SelectionButtonWasReleased()) //TODO mahdollisesti kaks nappia pohjassa 
		{
			//Vector3 endDistance = wand1.transform.position - wand2.transform.position;
			Vector3 endDistance = wand1.transform.position - controller2StartLoc;
			scaleUpdate(startDistance, endDistance);
		}
	}

	void scaleUpdate(Vector3 startDistance, Vector3 endDistance) {
		float newScaleX = initialScaling.x * (Mathf.Abs (endDistance.x/startDistance.x));
		float newScaleY = initialScaling.y * (Mathf.Abs (endDistance.y/startDistance.y));
		float newScaleZ = initialScaling.z * (Mathf.Abs (endDistance.z/startDistance.z));
		this.transform.localScale = new Vector3(newScaleX, newScaleY, newScaleZ);
	}
}
