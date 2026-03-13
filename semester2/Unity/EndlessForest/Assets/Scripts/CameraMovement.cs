using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{

    public Transform deer;

    // Update is called once per frame
    void Update()
    {
        transform.position = new Vector3(
            deer.position.x + 3.5f,
            transform.position.y,
            transform.position.z
        );
    }
}
