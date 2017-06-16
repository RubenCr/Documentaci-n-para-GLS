using UnityEngine;
using System.Collections;

public class ThrowObject : MonoBehaviour
{
    private Transform player;
    private Transform playerCam;
    public float distanceToBeCarried;
    public float throwForce = 10;
    bool hasPlayer = false;
    bool beingCarried = false;
    public AudioClip[] soundToPlay;
    private AudioSource audio;
    public int dmg;
    private bool touched = false;
    private Camera camr;

    void Start()
    {
        audio = GetComponent<AudioSource>();
    }

    void Update()
    {
        player = GameObject.Find("FPSController").GetComponent<Transform>();
        playerCam = GameObject.Find("FirstPersonCharacter").GetComponent<Transform>();

        float dist = Vector3.Distance(gameObject.transform.position, player.position);

        if (dist <= distanceToBeCarried)
        {
            hasPlayer = true;
        }
        else
        {
            hasPlayer = false;
        }
        if (beingCarried)
        {
            throwAppleIfNecessary();
        }
        else {
            takeAppleIfPossible();
        }
    }

    void takeAppleIfPossible()
    {
        RaycastHit hit;
        camr = playerCam.GetComponentInParent<Camera>();
        Vector3 rayOrigin = camr.ViewportToWorldPoint(new Vector3(0.5f, 0.5f, 0));
        Debug.DrawRay(rayOrigin, camr.transform.forward * (distanceToBeCarried + 1));

        if (Physics.Raycast(rayOrigin, camr.transform.forward, out hit, (distanceToBeCarried + 1)))
        {
            if (hasPlayer && Input.GetMouseButtonDown(0) && !beingCarried && 
                hit.collider.name == gameObject.name)
            {
                GetComponent<Rigidbody>().isKinematic = true;
                transform.parent = playerCam;
                beingCarried = true;
            }
        }
    }

    void throwAppleIfNecessary()
    {
        if (touched)
        {
            GetComponent<Rigidbody>().isKinematic = false;
            transform.parent = null;
            beingCarried = false;
            touched = false;
        }else
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