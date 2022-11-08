using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour
{
    public Vector2 InputVector { get; private set; }

    public Vector3 MousePosition { get; private set; }

    void Update()
    {
        MousePosition = Mouse.current.position.ReadValue();
    }

    public void Movement(InputAction.CallbackContext ctx) => InputVector = ctx.ReadValue<Vector2>();
}