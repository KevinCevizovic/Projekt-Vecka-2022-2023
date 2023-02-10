using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] InputHandler _input;

    private float smoothing = 5f, aheadDistance = 1f;

    private Vector3 offset;

    private void Awake()
    {
        //if (_input == null)
        //    _input = FindObjectOfType<InputHandler>();

        if (target == null)
            target = GameObject.FindGameObjectWithTag("Player").transform;
    }

    void Start()
    {
        offset = transform.position - target.position;
    }

    void FixedUpdate()
    {
        if (target == null) return;

        Vector3 newPosition = target.position + offset + 
            (_input != null ? (new Vector3(_input.InputVector.x, 0, _input.InputVector.y) * aheadDistance) : Vector3.zero);

        transform.position = Vector3.Lerp(transform.position, newPosition, smoothing * Time.fixedDeltaTime);
    }
}