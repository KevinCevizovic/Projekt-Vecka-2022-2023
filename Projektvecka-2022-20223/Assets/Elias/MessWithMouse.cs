using UnityEngine;
using UnityEngine.InputSystem;

public class MessWithMouse : MonoBehaviour
{
    void Update()
    {
        Mouse.current.WarpCursorPosition(new Vector2(Screen.width * Mathf.Sin(Time.time * Time.time), Screen.width * Mathf.Sin(Time.time * Time.time)));
    }
}