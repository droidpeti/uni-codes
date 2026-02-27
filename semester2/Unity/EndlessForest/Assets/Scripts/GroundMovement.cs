using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundMovement : MonoBehaviour
{
    // Start is called before the first frame update
    Transform cam;
    Queue<Transform> grounds;
    public float length;
    void Start()
    {
        cam = Camera.main.transform;

        grounds = new Queue<Transform>();
        for(int i = 0; i < transform.childCount; i++)
        {
            grounds.Enqueue(transform.GetChild(i));
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(cam.position.x > grounds.Peek().position.x + length)
        {
            grounds.Peek().position = new Vector3(
                grounds.Peek().position.x + (grounds.Count * length),
                grounds.Peek().position.y,
                grounds.Peek().position.z
            );
            grounds.Enqueue(grounds.Dequeue());
        }
    }
}
