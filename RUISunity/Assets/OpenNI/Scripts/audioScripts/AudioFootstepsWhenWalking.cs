using UnityEngine;
using System.Collections;

public class AudioFootstepsWhenWalking : MonoBehaviour {
	
	
	private AudioSource audio;
	
	// Use this for initialization
	void Start () {
		
		audio = gameObject.GetComponent<AudioSource>();
	}
	
	// Update is called once per frame
	void Update () {
		
		if (Input.GetButtonDown ("Horizontal") || Input.GetButtonDown ("Vertical") && !audio.isPlaying) 
		{
			audio.Play ();
		} 
		else if (!Input.GetButton ("Horizontal") && !Input.GetButton ("Vertical") && audio.isPlaying) 
		{
			audio.Stop ();
		}
		
		
	}
}
