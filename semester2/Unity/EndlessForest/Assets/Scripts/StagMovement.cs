using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StagMovement : MonoBehaviour
{
    // Start is called before the first frame update
    // When you press enter start the Stag
    // Move the deer physically
    // If Space is pressed Jump

    Animator anim;
    bool isRunning, isJumping = false;
    void Start()
    {
        anim = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!isRunning && Input.GetKeyDown(KeyCode.Return))
        {
            isRunning = true;
            anim.SetBool("startRun", true);
        }

        if (!isJumping && isRunning && Input.GetKeyDown(KeyCode.Space))
        {
            isJumping = true;
            anim.SetTrigger("jump");
        }
    }
}
