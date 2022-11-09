using UnityEngine;

[RequireComponent(typeof(InputHandler))]
public class TopDownCharacterMover : MonoBehaviour
{
    private InputHandler _input;

    [SerializeField] bool rotateTowardMouse;

    [SerializeField] float movementSpeed, rotationSpeed, maxRunningSpeed;
    private float speed, runningSpeed;

    [SerializeField] float desiredDuration;
    private float elapsedTime;

    [SerializeField] Camera Camera;

    [SerializeField] bool running;

    [SerializeField] AnimationCurve curve;

    private void Awake()
    {
        _input = GetComponent<InputHandler>();
    }

    void Update()
    {
        var targetVector = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);
        var movementVector = MoveTowardTarget(targetVector);

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
        elapsedTime += Time.deltaTime;
        float percentageComplete = elapsedTime / desiredDuration;

        runningSpeed = Mathf.Lerp(movementSpeed, maxRunningSpeed, curve.Evaluate(percentageComplete));
        // if running you go faster
        speed = (_input.Running ? runningSpeed * movementSpeed : movementSpeed) * Time.deltaTime;

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