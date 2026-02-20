using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallController : MonoBehaviour
{
    // Start is called before the first frame update

    // 1. Spawn Ball on key hit
    public GameObject ball;
    public Color color;

    Queue<GameObject> ballContainer = new Queue<GameObject>();
    int limit = 10;
    void Start()
    {
        Debug.Log("Ball");
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            GameObject newBall = null;
            if(ballContainer.Count < limit)
            {
                newBall = Instantiate(ball);
                ballContainer.Enqueue(newBall);
                Debug.Log("Spawn");
            }
            else
            {
                newBall = ballContainer.Dequeue();
                ballContainer.Enqueue(newBall);
                Debug.Log("Respawn");
            }

            newBall.GetComponent<Transform>().position = new Vector3(
                Random.Range(-5.0f, 5.0f),
                Random.Range(2.0f, 5.0f),
                Random.Range(-5.0f, 5.0f)
            );
            //newBall.GetComponent<MeshRenderer>().material.color = color;
            newBall.GetComponent<MeshRenderer>().material.color = new Color(
                Random.Range(0f, 1f),
                Random.Range(0f, 1f),
                Random.Range(0f, 1f)
            );

            if (!newBall.GetComponent<Ball>())
            {
                newBall.AddComponent<Ball>();
            }
        }  
    }
}
