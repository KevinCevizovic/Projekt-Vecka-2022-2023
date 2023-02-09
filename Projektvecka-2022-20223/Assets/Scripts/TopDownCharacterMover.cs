using UnityEngine;

[RequireComponent(typeof(InputHandler))]
public class TopDownCharacterMover : MonoBehaviour
{
    [SerializeField] bool rotateTowardMouse = true;

    [SerializeField] float walkingSpeed = 10, rotationSpeed = 5, maxRunningSpeed = 20;
    private float speed, runningSpeed;

    [SerializeField] float lerpDuration = 1;
    private float elapsedTime;

    [SerializeField] AnimationCurve curve;

    [SerializeField] Camera Camera;
    [SerializeField] InputHandler _input;

    Vector3 previousPositionXZ;

    Vector3 TransformPositionXZ => new Vector3(transform.position.x, 0, transform.position.z);

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
        /* var movementVector = */
        MoveTowardTarget(targetVector);

        if (rotateTowardMouse)
            RotateToMouseVector();
        else
            RotateTowardsVector(TransformPositionXZ - previousPositionXZ);
        //RotateTowardMovementVector(movementVector);

        previousPositionXZ = TransformPositionXZ;
    }

    private void RotateToMouseVector()
    {
        Ray ray = Camera.ScreenPointToRay(_input.MousePosition);

        if (Physics.Raycast(ray, out var hit, maxDistance: 300f))
        {
            var target = hit.point;
            target.y = transform.position.y;

            RotateTowardsVector(target);
        }
    }

    private void RotateTowardsVector(Vector3 vector)
    {
        if (vector.magnitude == 0) return;

        var rotation = Quaternion.LookRotation(new Vector3(vector.x, 0f, vector.z));
        transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, rotationSpeed);
    }

    // change this
    private Vector3 MoveTowardTarget(Vector3 targetVector)
    {
        if (_input.Running) // run
        {
            // lerping speed
            elapsedTime += Time.deltaTime;
            float percentageComplete = elapsedTime / lerpDuration;

            runningSpeed = Mathf.Lerp(walkingSpeed, maxRunningSpeed, curve.Evaluate(percentageComplete));
        }
        else elapsedTime = 0; // not run

        // if running you go faster
        speed = (_input.Running ? runningSpeed : walkingSpeed) * Time.deltaTime;

        targetVector = Quaternion.Euler(0, Camera.gameObject.transform.rotation.eulerAngles.y, 0) * targetVector.normalized;
        var targetPosition = transform.position + targetVector * speed;
        transform.position = targetPosition;
        return targetVector;
    }
}