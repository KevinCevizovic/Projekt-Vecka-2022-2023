using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class PlaceOnGround : MonoBehaviour
{
#if UNITY_EDITOR
    [CustomEditor(typeof(PlaceOnGround))]
    public class PickupEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            PlaceOnGround script = (PlaceOnGround)target;
            if (GUILayout.Button("PlaceOnGround"))
            {
                script._PlaceOnGround();
            }
            base.OnInspectorGUI();
        }
    }
#endif
    [SerializeField] LayerMask ground = 1 << 9;

    private void Start()
    {
        _PlaceOnGround();
    }

    public void _PlaceOnGround()
    {
        if (Physics.Raycast((1000f * Vector3.up) + transform.position, Vector3.down, out var hit, 2000f, ground)) // check where ground is(1000m above or below is limit)
        {
            // place on ground
            Vector3 groundPosition = hit.point;
            transform.position = groundPosition;
        }
    }
}