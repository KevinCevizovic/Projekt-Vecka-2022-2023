using UnityEngine;
using UnityEngine.InputSystem;

public class MessWithMouse : MonoBehaviour
{
    private void OnValidate()
    {
        InvokeRepeating(nameof(Mess), 0f, 0.1f);
    }

    private void Mess() => Mouse.current.WarpCursorPosition(new Vector2(Screen.width * 0.5f + Screen.width * Mathf.Sin(Time.time * Time.time * 0.1f) * 0.3f, Screen.width * Mathf.Sin(Time.time * Time.time * 0.1f) * 0.3f));
}