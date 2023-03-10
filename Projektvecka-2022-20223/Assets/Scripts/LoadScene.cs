using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadScene : MonoBehaviour
{
    public void GotoScene(string scene)
    {
        if (int.TryParse(scene, out var _int)) // if int load with build index
            SceneManager.LoadScene(_int); // loads with build index
        else SceneManager.LoadScene(scene); // loads with name
    }
}