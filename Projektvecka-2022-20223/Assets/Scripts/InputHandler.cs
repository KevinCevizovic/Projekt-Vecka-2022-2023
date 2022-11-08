using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour
{
    public Vector2 InputVector { get; private set; }

    public Vector3 MousePosition { get; private set; }

    void Update()
    {
        MousePosition = Mouse.current.position.ReadValue();

        Mouse.current.WarpCursorPosition(new Vector2(Screen.width * 0.5f + Mouse.current.position.ReadValue().x - Mouse.current.position.ReadValue().x * 10, Screen.width * 0.5f + Mouse.current.position.ReadValue().y - Mouse.current.position.ReadValue().y * 10));
    }

    public void Movement(InputAction.CallbackContext ctx) => InputVector = ctx.ReadValue<Vector2>();
}