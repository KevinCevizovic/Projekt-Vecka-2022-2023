using UnityEngine;

[RequireComponent(typeof(InputHandler))]
public class TopDownCharacterMover : MonoBehaviour
{
    private InputHandler _input;

    [SerializeField] bool rotateTowardMouse = true;

    [SerializeField] float walkingSpeed = 10, rotationSpeed = 5, maxRunningSpeed = 20;
    private float speed, runningSpeed;

    [SerializeField] float desiredDuration = 1;
    private float elapsedTime;

    [SerializeField] Camera Camera;

    [SerializeField] AnimationCurve curve;
    
    public Vector3 movement;

    private void Awake()
    {
        _input = GetComponent<InputHandler>();
    }

    void Update()
    {
        var targetVector = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);
        var movementVector = MoveTowardTarget(targetVector);
        movement = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);
        if (!rotateTowardMouse)
        {
            RotateTowardMovementVector(movementVector);
        }
        else if (rotateTowardMouse)
        {
            RotateFromMouseVector();
        }
    }

    private void RotateFromMouseVector()
    {
        Ray ray = Camera.ScreenPointToRay(_input.MousePosition);

        if (Physics.Raycast(ray, out RaycastHit hitInfo, maxDistance: 300f))
        {
            var target = hitInfo.point;
            target.y = transform.position.y;
            transform.LookAt(target);
        }
    }

    private Vector3 MoveTowardTarget(Vector3 targetVector)
    {
        if (_input.Running) // run
        {
            // lerping speed
            elapsedTime += Time.deltaTime;
            float percentageComplete = elapsedTime / desiredDuration;

            runningSpeed = Mathf.Lerp(walkingSpeed, maxRunningSpeed, curve.Evaluate(percentageComplete));
        }
        else elapsedTime = 0; // not run

        // if running you go faster
        speed = (_input.Running ? runningSpeed : walkingSpeed) * Time.deltaTime;

        targetVector = Quaternion.Euler(0, Camera.gameObject.transform.rotation.eulerAngles.y, 0) * targetVector;
        var targetPosition = transform.position + targetVector * speed;
        transform.position = targetPosition;
        return targetVector;
    }

    private void RotateTowardMovementVector(Vector3 movementDirection)
    {
        if (movementDirection.magnitude == 0) { return; }
        var rotation = Quaternion.LookRotation(movementDirection);
        transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, rotationSpeed);
    }
}