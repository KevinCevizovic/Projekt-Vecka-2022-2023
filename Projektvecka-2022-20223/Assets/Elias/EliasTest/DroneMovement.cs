using UnityEngine;

public class DroneMovement : MonoBehaviour
{
    public enum DroneStates
    {
        idle,
        hovering,
        chasing,
        controlling
    }
    public DroneStates droneState;

    [SerializeField] float hoverHeight = 3f;

    [SerializeField] LayerMask ground = 1 << 9;

    private void Update()
    {
        switch (droneState)
        {
            case DroneStates.idle:
                break;
            case DroneStates.hovering:
                Hover();
                break;
            case DroneStates.chasing:
                break;
            case DroneStates.controlling:
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
            transform.position = hit.point + Vector3.one * 3f;
        }
    }
}