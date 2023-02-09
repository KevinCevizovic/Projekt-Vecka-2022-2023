using UnityEngine.SceneManagement;
using UnityEngine;

public class MainMenu : MonoBehaviour
{
    public GameObject backgroundImage;
    public GameObject btn_1;
    public GameObject text_1;
    public GameObject btn_2;
    public GameObject text_2;
    public GameObject btn_3;
    public GameObject text_3;

    public void Continue()
    {
        try
        {
            backgroundImage.SetActive(false);
            btn_1.SetActive(false);
            btn_2.SetActive(false);
            btn_3.SetActive(false);
            text_1.SetActive(false);
            text_2.SetActive(false);
            text_3.SetActive(false);
        }
        catch
        {
        }
    }

    public void ShowMenu()
    {
        try
        {
            backgroundImage.SetActive(true);
            btn_1.SetActive(true);
            btn_2.SetActive(true);
            btn_3.SetActive(true);
            text_1.SetActive(true);
            text_2.SetActive(true);
            text_3.SetActive(true);
        }
        catch
        {
        }
    }

    public void ChangeScene(string desiredScene)
    {
        try
        {
            backgroundImage.SetActive(false);
            btn_1.SetActive(false);
            btn_2.SetActive(false);
            btn_3.SetActive(false);
            text_1.SetActive(false);
            text_2.SetActive(false);
            text_3.SetActive(false);
        }
        catch
        {
        }
        SceneManager.LoadScene(desiredScene);
    }

    public void RestartScene()
    {
        try
        {
            backgroundImage.SetActive(false);
            btn_1.SetActive(false);
            btn_2.SetActive(false);
            btn_3.SetActive(false);
            text_1.SetActive(false);
            text_2.SetActive(false);
            text_3.SetActive(false);
        }
        catch
        {
        }

        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void Quit()
    {
        Application.Quit();
    }

}
