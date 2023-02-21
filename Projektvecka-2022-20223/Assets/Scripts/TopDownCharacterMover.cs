using UnityEngine;

[RequireComponent(typeof(InputHandler))]
public class TopDownCharacterMover : MonoBehaviour
{
    [SerializeField] bool rotateTowardMouse = true;

    //[SerializeField] float walkingSpeed = 10;
    [SerializeField] float rotationSpeed = 5;
    [SerializeField] float runningSpeed = 20;
    //private float speed;

    //[SerializeField] float lerpDuration = 1;
    //private float elapsedTime;

    [SerializeField] AnimationCurve curve;

    [SerializeField] Camera Camera;
    [SerializeField] InputHandler _input;

    Vector3 previousPosition;

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
        MoveTowardTarget(targetVector);

        if (rotateTowardMouse)
            RotateTowardsMouseVector();
        else
        {
            //RotateTowardsVector(TransformPositionXZ - previousPositionXZ);
            previousPosition.y = transform.position.y;
            RotateTowardsVector(transform.position - previousPosition);
        }

        //previousPositionXZ = TransformPositionXZ;
        previousPosition = transform.position;
    }

    private void RotateTowardsMouseVector()
    {
        Ray ray = Camera.ScreenPointToRay(_input.MousePosition);

        if (Physics.Raycast(ray, out var hit, 100f))
        {
            var target = hit.point - transform.position;
            //target.y = transform.position.y;
            target.y = 0;

            RotateTowardsVector(target);
        }
    }

    private void RotateTowardsVector(Vector3 vector)
    {
        if (vector.magnitude == 0) return;

        var rotation = Quaternion.LookRotation(vector);
        transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, rotationSpeed);
    }

    // change this(ok)
    private void MoveTowardTarget(Vector3 targetVector)
    {
        targetVector = Quaternion.Euler(0, Camera.gameObject.transform.rotation.eulerAngles.y, 0) * targetVector.normalized;

        transform.position += runningSpeed * Time.deltaTime * targetVector;


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
}