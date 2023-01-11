using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour
{
    public Vector2 InputVector { get; private set; }

    public Vector3 MousePosition { get; private set; }

    public bool Running { get; private set; }

    [SerializeField] Pickup pickup;

    private void Awake()
    {
        if (pickup == null)
            GetComponent<Pickup>();
    }

    void Update()
    {
        MousePosition = Mouse.current.position.ReadValue();
    }

    public void Movement(InputAction.CallbackContext ctx) => InputVector = ctx.ReadValue<Vector2>();

    public void Run(InputAction.CallbackContext ctx) => Running = ctx.performed;

    public void DropItem(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
            pickup.DropItem();
    }
}