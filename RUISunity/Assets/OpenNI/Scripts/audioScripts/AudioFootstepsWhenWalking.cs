using UnityEngine;
using System.Collections;

public class AudioFootstepsWhenWalking : MonoBehaviour {
	
	
	private AudioSource audio;
	private RUISCharacterController charControl;
	
	// Use this for initialization
	void Start () {

        charControl = gameObject.GetComponent<RUISCharacterController>();
		audio = gameObject.GetComponent<AudioSource>();
	}
	
	// Update is called once per frame
	void Update () {

        if (charControl.grounded && !audio.isPlaying && ( Input.GetButton("Horizontal") || Input.GetButton("Vertical") ) ) 
		{
			audio.Play ();
		}
        else if (!charControl.grounded && audio.isPlaying || !Input.GetButton("Horizontal") && !Input.GetButton("Vertical") && audio.isPlaying ) 
		{
			audio.Stop ();
		}
		
		
	}
}
