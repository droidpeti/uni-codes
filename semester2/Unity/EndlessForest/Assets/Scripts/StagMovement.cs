using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.UI;

public class StagMovement : MonoBehaviour
{
    // Start is called before the first frame update
    // When you press enter start the Stag
    // Move the deer physically
    // If Space is pressed Jump

    Animator anim;
    AudioSource sound;
    bool isRunning, isJumping, isGameover = false;
    int score = 0;
    readonly float speed = 7.5f;

    public Text scoreText;
    public AudioClip jumpSound;
    void Start()
    {
        anim = GetComponent<Animator>();
        sound = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        if (!isRunning && !isGameover && Input.GetKeyDown(KeyCode.Return))
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

    void OnTriggerEnter2D(Collider2D collision)
    {
        if(collision.tag == "Collectable")
        {
            collision.gameObject.GetComponent<ParticleSystem>().Play();

            collision.gameObject.GetComponent<Animator>().Play("collect");

            collision.gameObject.GetComponent<AudioSource>().Play();

            score++;
            scoreText.text = $"Score: {score}";
        }
        else if(collision.tag == "Obstacle")
        {
            collision.gameObject.GetComponent<AudioSource>().Play();
            isGameover = true;
            isRunning = false;
            anim.Play("sleep");
            sound.Stop();
        }
    }
}
