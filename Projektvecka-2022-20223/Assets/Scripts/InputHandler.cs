using UnityEngine;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour
{
    public Vector2 InputVector { get; private set; }

    public Vector3 MousePosition { get; private set; }

    void Update()
    {
        //var h = Input.GetAxis("Horizontal");
        //var v = Input.GetAxis("Vertical");


        //InputVector = Vector3.Normalize(new Vector2(h, v));

        MousePosition = Mouse.current.position.ReadValue();
    }

    float e;
    public void Movement(InputAction.CallbackContext ctx) => e = ctx.ReadValue<Vector2>().x;

    public void TestAction()
    {
        //Debug.Log(ctx);
        Debug.Log("e");
    }
    //float hMove;
    //public void Movement(InputAction.CallbackContext ctx) => hMove = ctx.ReadValue<Vector2>().x;
}