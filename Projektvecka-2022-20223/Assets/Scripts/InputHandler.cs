using System;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

[Serializable] public class InputEvent : UnityEvent { }
public class InputHandler : MonoBehaviour
{
    public InputEvent OnDrop;

    public InputEvent OnLeftClick, OnRightClick;

    public InputEvent OnCommunicate;

    public Vector2 InputVector { get; private set; }

    public Vector3 MousePosition { get; private set; }

    public bool Running { get; private set; }

    void Update()
    {
        MousePosition = Mouse.current.position.ReadValue();
    }

    public void Movement(InputAction.CallbackContext ctx) => InputVector = ctx.ReadValue<Vector2>();

    public void Run(InputAction.CallbackContext ctx) => Running = ctx.performed;

    public void DropItem(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
            OnDrop?.Invoke();
    }

    public void LeftClick(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
            OnLeftClick?.Invoke();
    }

    public void RightClick(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
            OnRightClick?.Invoke();
    }

}