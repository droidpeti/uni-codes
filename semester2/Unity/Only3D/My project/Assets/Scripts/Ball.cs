using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ball : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        //StartCoroutine(Despawn());
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator Despawn()
    {
        yield return new WaitForSeconds(3);
        Destroy(gameObject);
    }


    void OnCollisionEnter(Collision collision)
    {
        if(collision.transform.name == "Death Barrier")
        {
            Destroy(gameObject);
            Debug.Log("Destroyed Ball on Death Barrier");
        }
    }
}
