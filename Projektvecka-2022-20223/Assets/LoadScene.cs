using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadScene : MonoBehaviour
{
    public void GotoScene(string scene = null)
    {
        if (scene == null) SceneManager.LoadScene(0); // loads scene 0 if not specified

        if (int.TryParse(scene, out var _int)) // if scene is a number load with build index
            SceneManager.LoadScene(_int); // loads with build index
        else SceneManager.LoadScene(scene); // loads with name
    }
}