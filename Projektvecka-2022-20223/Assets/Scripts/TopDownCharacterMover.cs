using UnityEngine;
using UnityEngine.InputSystem;

public class TopDownCharacterMover : MonoBehaviour
{
    [Header("Rotation")]
    [SerializeField] private bool rotateTowardMouse = true;
    [SerializeField] private float rotationSpeed = 5f;

    [Header("Movement")]
    [SerializeField] private float speed = 14f;
    private Vector3 lastPosition;

    [Header("Roll")]
    [SerializeField] private float rollingSpeed = 17f;
    [SerializeField] private float rollTime = 0.3f;
    public bool Rolling { get; private set; }
    private Vector3 rollDir;

    [Header("Acceleration")]
    [SerializeField] private float accelerationDuration = 0.3f;
    [SerializeField] private AnimationCurve accelerationCurve;
    private float acceleration, accelerationStartTime, accelerationElapsedTime;

    // refrences
    new private Camera camera;

    // input
    private Vector2 inputVector;

    private void Awake()
    {
        if (camera == null)
            camera = Camera.main;

        if (accelerationCurve.length == 0)
        {
            accelerationCurve.AddKey(0f, 0f);
            accelerationCurve.AddKey(1f, 1f);
        }
    }

    void Update()
    {
        var moveDir = transform.position - lastPosition;

        if (Rolling)
        {
            if (rollDir == Vector3.zero) // when first rolling
                rollDir = moveDir.normalized; // set roll dir

            Roll();

            return;
        }
        else rollDir = Vector3.zero; // when not rolling


        if (rotateTowardMouse)
            RotateTowardsMousePosition();
        else
        {
            var moveDirXZ = new Vector3(moveDir.x, 0f, moveDir.z);
            if (moveDirXZ != Vector3.zero)
                RotateTowardMovementVector(moveDirXZ);
        }

        lastPosition = transform.position;

        if (accelerationDuration != 0)
            CalculateAcceleration();
        else acceleration = 1f;

        Move(new Vector3(inputVector.x, 0, inputVector.y));
    }

    private void Roll()
    {
        transform.position += Quaternion.Euler(0, camera.transform.rotation.eulerAngles.y, 0) * rollDir * rollingSpeed * Time.deltaTime;
    }

    private void CalculateAcceleration()
    {
        accelerationElapsedTime = Time.time - accelerationStartTime;

        acceleration = accelerationCurve.Evaluate(Mathf.Clamp01(accelerationElapsedTime) / accelerationDuration);
    }

    private void Move(Vector3 movementVector)
    {
        transform.position += Quaternion.Euler(0, camera.transform.rotation.eulerAngles.y, 0) * movementVector * acceleration * speed * Time.deltaTime;
    }

    private void RotateTowardsMousePosition()
    {
        var mousePos = Mouse.current.position.ReadValue();
        Ray ray = camera.ScreenPointToRay(mousePos);

        if (Physics.Raycast(ray, out RaycastHit hitInfo, maxDistance: 300f))
        {
            var target = hitInfo.point;
            target.y = transform.position.y;
            transform.LookAt(target);
        }
    }

    private void RotateTowardMovementVector(Vector3 movementDirection)
    {
        if (movementDirection.magnitude == 0) { return; }
        var rotation = Quaternion.LookRotation(movementDirection);
        transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, rotationSpeed);
    }

    #region Input

    public void MovementInput(InputAction.CallbackContext ctx)
    {
        inputVector = ctx.ReadValue<Vector2>();

        if (ctx.started)
            accelerationStartTime = Time.time;
    }

    public void RollInput(InputAction.CallbackContext ctx)
    {
        if (ctx.started && !Rolling)
        {
            Rolling = true;
            Invoke(nameof(ResetRolling), rollTime);
        }
    }

    void ResetRolling() => Rolling = false;

    #endregion
}