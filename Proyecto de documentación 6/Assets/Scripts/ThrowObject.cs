using UnityEngine;
using System.Collections;

public class ThrowObject : MonoBehaviour
{
    private Transform player;
    private Transform playerCam;
    public float throwForce = 10;
    bool hasPlayer = false;
    bool beingCarried = false;
    public AudioClip[] soundToPlay;
    private AudioSource audio;
    public int dmg;
    private bool touched = false;

    void Start()
    {
        audio = GetComponent<AudioSource>();
    }

    void Update()
    {
        player = GameObject.Find("FPSController").GetComponent<Transform>();
        playerCam = GameObject.Find("FirstPersonCharacter").GetComponent<Transform>();

        float dist = Vector3.Distance(gameObject.transform.position, player.position);
        if (dist <= 4.0f)
        {
            hasPlayer = true;
        }
        else
        {
            hasPlayer = false;
        }
        if (beingCarried)
        {
            if (touched)
            {
                GetComponent<Rigidbody>().isKinematic = false;
                transform.parent = null;
                beingCarried = false;
                touched = false;
            }
            if (Input.GetMouseButtonDown(0))
            {

                GetComponent<Rigidbody>().isKinematic = false;
                transform.parent = null;
                beingCarried = false;
                GetComponent<Rigidbody>().AddForce(playerCam.forward * throwForce);
                //RandomAudio();
            }
            else if (Input.GetMouseButtonDown(1))
            {
                GetComponent<Rigidbody>().isKinematic = false;
                transform.parent = null;
                beingCarried = false;
            }
        } else 
        if (hasPlayer && Input.GetMouseButtonDown(0) && !beingCarried)
        {
            GetComponent<Rigidbody>().isKinematic = true;
            transform.parent = playerCam;
            beingCarried = true;
        }
    }
    void RandomAudio()
    {
        if (audio.isPlaying)
        {
            return;
        }
        audio.clip = soundToPlay[Random.Range(0, soundToPlay.Length)];
        audio.Play();

    }
    void OnTriggerEnter()
    {
        if (beingCarried)
        {

            touched = true;
        }
    }
}