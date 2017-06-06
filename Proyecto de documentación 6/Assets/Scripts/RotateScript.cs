using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateScript : MonoBehaviour {
    private GameObject player;
    private Transform playerPosition;

    public int speedMultiplier;

    private double distance;

    //Distance in wich the asociated GameObject Starts to rotate.
    public int maximumDistanceToRotate;

	// Use this for initialization
	void Start () {
        player = GameObject.Find("FirstPersonCharacter");
        playerPosition = player.transform;
        maximumDistanceToRotate = 20;
        //speedMultiplier = 10;
        updateDistance();
        rotateAroundItself();
   
        //GameObject prefabTree = GameObject.Find("Tree prefab");
        //prefabTree.transform.localScale = new Vector3(10f, 10f, 10f);
        //transform.localScale = new Vector3(10F, 10F, 10F);

    }
	
	// Update is called once per frame
	void Update () {
        updateDistance();
        rotateAroundItself();
    }

    //Updates the distance between the player and the GameObject that uses this script.
    private void updateDistance()
    {
        distance = Vector3.Distance(playerPosition.position, transform.position);
    }

    //Cause the GameObject using this script to rotate around itself. 
    private void rotateAroundItself()
    {
        if (distance <= maximumDistanceToRotate)
        {
            //The closer is the player, the faster this GameObjet rotate.
            int speed = (int)(maximumDistanceToRotate - distance) * speedMultiplier;

            //Rotate the object around its "Y" axis (Vector3.up) at speed (the value of speed) grades per second.
            transform.Rotate(Vector3.up * Time.deltaTime * speed, Space.Self);
            
            //transform.Rotate(Time.deltaTime * speed, Time.deltaTime * speed, Time.deltaTime * speed, Space.Self);

        }
    }

    ////Multiplied by the base speed. Allows to see and change the speed of the game that rotate. 
    //public int SpeedMultiplier
    //{
    //    get
    //    {
    //        return speedMultiplier;
    //    }
    //    set
    //    {
    //        speedMultiplier = value;
    //    }
    //}
}
