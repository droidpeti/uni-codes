using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectableController : MonoBehaviour
{
    // Start is called before the first frame update
    Transform target;
    float offset = 7.0f;
    void Start()
    {
        target = FindFirstObjectByType<StagMovement>().transform;
    }

    // Update is called once per frame
    void Update()
    {
        if(transform.position.x + offset < target.position.x)
        {
            float minRange = 30.0f;
            float maxRange = 50.0f;
            if(tag == "Collectable")
            {
                GetComponent<Animator>().Play("idle_star");
                minRange = 50.0f;
                maxRange = 75.0f;
            }
            transform.position += Vector3.right * Random.Range(minRange, maxRange);
        }
    }
}
