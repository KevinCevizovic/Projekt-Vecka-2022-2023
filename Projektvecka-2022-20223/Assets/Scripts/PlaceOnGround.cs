using UnityEngine;

public class PlaceOnGround : MonoBehaviour
{
    [SerializeField] LayerMask ground = 1 << 9;

    private void Start()
    {
        if (Physics.Raycast((1000f * Vector3.up) + transform.position, Vector3.down, out var hit, 2000f, ground)) // check where ground is(1000m above or below is limit)
        {
            // place on ground
            Vector3 groundPosition = hit.point;
            transform.position = groundPosition;
        }
    }
}