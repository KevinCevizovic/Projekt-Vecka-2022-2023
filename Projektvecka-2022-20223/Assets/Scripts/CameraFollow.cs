using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    [SerializeField] Transform target;

    public float smoothing = 5f, aheadDistance = 1f;

    private Vector3 offset, targetLastPos;

    private void Awake()
    {
        if (target == null)
            target = GameObject.FindGameObjectWithTag("Player").transform;
    }

    void Start()
    {
        offset = transform.position - target.position;
    }

    void LateUpdate()
    {
        if (target == null) return;

        Vector3 targetDirection = target.position - targetLastPos;

        Vector3 newPosition = target.position + offset + (targetDirection * aheadDistance);

        if (smoothing == 0)
            transform.position = newPosition;
        else transform.position = Vector3.Lerp(transform.position, newPosition, smoothing * Time.deltaTime);

        targetLastPos = target.position;
    }
}