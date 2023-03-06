using UnityEngine;
using UnityEngine.InputSystem;

public class MovementTest : MonoBehaviour
{
    [SerializeField] private bool rotateTowardMouse = true;

    [SerializeField] private float rotationSpeed = 5, speed = 10/*, rollingSpeed = 15*/;

    //[SerializeField] private float accelerationSpeed, deaccelerationSpeed;
    [SerializeField] private float accelerationTime = 0.3f;
    private float accelerationDuration = 0;

    [SerializeField] AnimationCurve accelerationCurve;
    private float acceleration;


    //float walkingSpeed = 10,
    //, maxRunningSpeed = 20;
    //private float speed, runningSpeed;

    //[SerializeField] float lerpDuration = 1;
    //private float elapsedTime;


    [SerializeField] new Camera camera;
    [SerializeField] InputHandler _input;

    Vector3 lastPosition;

    Vector2 inputVector;

    private void Awake()
    {
        if (_input == null)
            _input = GetComponent<InputHandler>();

        if (camera == null)
            camera = Camera.main;
    }

    void Update()
    {
        //var targetVector = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);

        var moveDir = transform.position - lastPosition;

        if (rotateTowardMouse)
            RotateTowardsMousePosition();
        else
            RotateTowardMovementVector(new Vector3(moveDir.x, 0f, moveDir.z));

        lastPosition = transform.position;

        //Move(targetVector);

        CalculateAcceleration();

        Move(new Vector3(inputVector.x, 0, inputVector.y));
    }

    private void CalculateAcceleration()
    {
        accelerationDuration += Time.deltaTime;

        acceleration = accelerationCurve.Evaluate(Mathf.Clamp01(accelerationDuration / accelerationTime));
    }

    private void Move(Vector3 movementVector)
    {
        transform.position += Quaternion.Euler(0, camera.transform.rotation.eulerAngles.y, 0) * movementVector * acceleration * speed * Time.deltaTime;

        //Debug.Log("1" + targetVector);
        //targetVector = Quaternion.Euler(0, Camera.gameObject.transform.rotation.eulerAngles.y, 0) * targetVector.normalized;
        //Debug.Log("2" + targetVector);
        //transform.position += targetVector * speed * Time.deltaTime;
        //Debug.Log(inputVector);
        //var posY = transform.position.y * Vector3.up;
        //transform.position = Vector3.MoveTowards(transform.position, transform.position /*+ posY*/ + inputVector, speed * Time.deltaTime);

        //if (_input.Running) // run
        //{
        //    // lerping speed
        //    elapsedTime += Time.deltaTime;
        //    float percentageComplete = elapsedTime / lerpDuration;

        //    runningSpeed = Mathf.Lerp(walkingSpeed, maxRunningSpeed, curve.Evaluate(percentageComplete));
        //}
        //else elapsedTime = 0; // not run

        //// if running you go faster
        //speed = (_input.Running ? runningSpeed : walkingSpeed) * Time.deltaTime;

        //targetVector = Quaternion.Euler(0, Camera.gameObject.transform.rotation.eulerAngles.y, 0) * targetVector.normalized;
        //var targetPosition = transform.position + targetVector * speed;
        //transform.position = targetPosition;
    }

    private void RotateTowardsMousePosition()
    {
        Ray ray = camera.ScreenPointToRay(_input.MousePosition);

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

    public void MovementInput(InputAction.CallbackContext ctx) => inputVector = ctx.ReadValue<Vector2>();

    #endregion
}