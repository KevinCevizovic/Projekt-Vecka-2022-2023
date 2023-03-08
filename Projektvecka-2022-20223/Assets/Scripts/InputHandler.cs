using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour
{
    public PlayerInput PlayerInput;

    public UnityEvent OnDrop;

    public UnityEvent OnLeftClick, OnRightClick;

    public UnityEvent OnCommunicate;

    public UnityEvent OnHeal;

    public UnityEvent OnKeyInput;

    public Transform weaponHolder;

    public Vector2 InputVector { get; private set; }

    public Vector3 MousePosition { get; private set; }

    public bool Running { get; private set; }

    void Update()
    {
        MousePosition = Mouse.current.position.ReadValue();

        // When perfomed the method plays

        PlayerInput.Player.Move.performed += Movement;

        PlayerInput.Player.Move.canceled += Movement;

        PlayerInput.Player.Run.performed += Run;

        PlayerInput.Player.DropItem.performed += DropItem;

        PlayerInput.Player.LeftClick.performed += LeftClick;

        PlayerInput.Player.RightClick.performed += RightClick;

        PlayerInput.Player.ThrowSpear.performed += ThrowSpear;

        PlayerInput.Player.UseHealthPotion.performed += Heal;

        // PlayerInput.Player.Communicate.performed += OnCommunicate;
    }

    private void Awake()
    {
        PlayerInput = new PlayerInput();
    }
    private void Start()
    {
        //weaponHolder = transform.GetChild(0);
    }

    private void OnEnable()
    {
        PlayerInput.Player.Enable();
    }

    private void OnDisable()
    {
        PlayerInput.Player.Disable();
    }

    public void Movement(InputAction.CallbackContext ctx) 
    { 
        InputVector = ctx.ReadValue<Vector2>(); 
    }

    public void Run(InputAction.CallbackContext ctx) 
    { 
        Running = !Running; 
    }

    public void Heal(InputAction.CallbackContext ctx)
    {
        OnHeal.Invoke();
    }


    public void DropItem(InputAction.CallbackContext ctx)
    {
        OnDrop.Invoke();
    }

    public void LeftClick(InputAction.CallbackContext ctx)
    {
        // weaponHolder.GetChild(0).GetComponent<Weapon_Spear>().LeftClick();

        OnLeftClick.Invoke();
    }

    public void RightClick(InputAction.CallbackContext ctx)
    {
        // weaponHolder.GetChild(0).GetComponent<Weapon_Spear>().RightClick();
        OnRightClick.Invoke();
    }

    public void ThrowSpear(InputAction.CallbackContext ctx)
    {
        // weaponHolder.GetChild(0).GetComponent<Weapon_Spear>().ThrowSpear();
        OnRightClick.Invoke();
    }
    /*
    public void OnCommunicate(InputAction.CallbackContext ctx)
    {
        // weaponHolder.GetChild(0).GetComponent<Weapon_Spear>().ThrowSpear();
        OnCommunicate.Invoke();
    }
    */
}