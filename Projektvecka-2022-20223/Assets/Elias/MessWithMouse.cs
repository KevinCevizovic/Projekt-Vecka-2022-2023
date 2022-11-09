using UnityEngine;
using UnityEngine.InputSystem;

public class MessWithMouse : MonoBehaviour
{
    void Update()
    {
        Mouse.current.WarpCursorPosition(new Vector2(Screen.width * 0.5f + Screen.width * Mathf.Sin(Time.time * Time.time * 0.1f) * 0.3f, Screen.width * Mathf.Sin(Time.time * Time.time * 0.1f) * 0.3f));
    }
}