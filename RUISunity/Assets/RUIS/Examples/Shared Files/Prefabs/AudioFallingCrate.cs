using UnityEngine;
using System.Collections;

public class AudioFallingCrate : MonoBehaviour {


	private AudioSource audio;

	// Use this for initialization
	void Start () {
	
		audio = gameObject.GetComponent<AudioSource>();
	
	}

	void OnCollisionEnter(Collision other)
	{
		if(audio != null)
		{
			audio.Play();
		}
	}
	// Update is called once per frame
	//void Update () {
	//
	//	audio.Play ();
	//
	//}
}
