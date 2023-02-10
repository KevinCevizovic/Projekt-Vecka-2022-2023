using UnityEngine;

public class BirdMovement : MonoBehaviour
{
    public enum BirdStates
    {
        idle,
        hovering,
        chasing,
        controlling
    }
    public BirdStates birdState;

    [SerializeField] float flightHeight = 3f,saga;

    [SerializeField] LayerMask ground = 1 << 9;

    private void Update()
    {
        switch (birdState)
        {
            case BirdStates.idle:
                break;
            case BirdStates.hovering:
                Hover();
                break;
            case BirdStates.chasing:
                break;
            case BirdStates.controlling:
                break;
            default:
                break;
        }
    }

    /// <summary> If hovering this is called every frame </summary>
    private void Hover()
    {
        if (Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 10f, ground))
        {
            Vector3.Lerp(transform.position, transform.position = hit.point + Vector3.up * 3f, Time.deltaTime);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawLine(transform.position, transform.position + Vector3.down * 3f);
    }
}