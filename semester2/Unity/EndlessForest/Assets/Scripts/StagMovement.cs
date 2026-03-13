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
    AudioSource sound;
    bool isRunning, isJumping = false;
    readonly float speed = 7.5f;
    public AudioClip jumpSound;
    void Start()
    {
        anim = GetComponent<Animator>();
        sound = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!isRunning && Input.GetKeyDown(KeyCode.Return))
        {
            isRunning = true;
            //anim.SetBool("startRun", true);
            anim.Play("run");
            sound.Play();
        }

        if (isRunning)
        {
            if (!isJumping&& Input.GetKeyDown(KeyCode.Space))
            {
                isJumping = true;
                sound.PlayOneShot(jumpSound);
                anim.SetTrigger("jump");
                isJumping = false;
            }
        }
    }

    void FixedUpdate() 
    {
        if (isRunning)
        {
            transform.position += Vector3.right * Time.fixedDeltaTime * speed;
        }
    }
}
