using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BackgroundMovement : MonoBehaviour
{
    // Start is called before the first frame update
    Transform cam;
    float length, startPosX, parallaxStrnegth, distance, tempPosX;
    void Start()
    {
        cam = Camera.main.transform;

        length = GetComponent<SpriteRenderer>().bounds.size.x;
        startPosX = transform.position.x;
        parallaxStrnegth = Mathf.Abs(GetComponent<SpriteRenderer>().sortingOrder) / 10f;

        transform.GetChild(0).position = new Vector3(
            startPosX + length,
            transform.GetChild(0).position.y,
            transform.GetChild(0).position.z
        );
    }

    // Update is called once per frame
    void Update()
    {
        tempPosX = cam.position.x * (1-parallaxStrnegth);

        distance = cam.position.x * parallaxStrnegth;
        transform.position = new Vector3(
            startPosX + distance,
            transform.position.y,
            transform.position.z
        );

        if(tempPosX > startPosX + length)
        {
            startPosX += length;
        }
    }
}
