using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class MenuController : MonoBehaviour
{
    public void StartGame()
    {
        int index = FindObjectOfType<Dropdown>().value;
        /*
        if(index == 0)
        {
            SceneManager.LoadScene("Platformer");
        }
        else
        {
            SceneManager.LoadScene("TopDown");
        }
        */
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1 + index);
    }
    public void Quit()
    {
        Application.Quit();
        #if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
        #endif
    }
}
