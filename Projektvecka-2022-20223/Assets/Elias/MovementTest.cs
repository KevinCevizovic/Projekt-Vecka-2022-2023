using UnityEngine;

public class MovementTest : MonoBehaviour
{
    [SerializeField] bool rotateTowardMouse = true;

    [SerializeField] float walkingSpeed = 10, rotationSpeed = 5, maxRunningSpeed = 20;
    private float speed, runningSpeed;

    [SerializeField] float lerpDuration = 1;
    private float elapsedTime;

    [SerializeField] AnimationCurve curve;

    [SerializeField] Camera Camera;
    [SerializeField] InputHandler _input;

    Vector3 lastPosition;

    private void Awake()
    {
        if (_input == null)
            _input = GetComponent<InputHandler>();

        if (Camera == null)
            Camera = Camera.main;
    }

    void Update()
    {
        var targetVector = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);

        if (rotateTowardMouse)
            RotateFromMouseVector();
        else
            RotateTowardMovementVector(lastPosition - transform.position);

        Move(targetVector);

        lastPosition = transform.position; // temporary
    }

    private void Move(Vector3 targetVector)
    {
        transform.position += targetVector;
    }

    private void RotateFromMouseVector()
    {
        Ray ray = Camera.main.ScreenPointToRay(_input.MousePosition);

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
}