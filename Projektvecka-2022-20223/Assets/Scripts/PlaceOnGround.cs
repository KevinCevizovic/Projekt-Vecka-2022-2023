using UnityEngine;

public class PlaceOnGround : MonoBehaviour
{
    [SerializeField] LayerMask ground = (1 << 9); // define ground

    private void Start()
    {
        if (Physics.Raycast(transform.position, Vector3.down, out var hit, Mathf.Infinity, ground)) // check where ground is
        {
            // place on ground
            Vector3 groundPosition = hit.point;
            transform.position = groundPosition;
        }
    }
}