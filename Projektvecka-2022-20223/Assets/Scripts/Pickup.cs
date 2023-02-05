using UnityEditor;
using UnityEngine;


public class Pickup : MonoBehaviour
{
#if UNITY_EDITOR
    [CustomEditor(typeof(Pickup))]
    public class PickupEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            Pickup pickup = (Pickup)target;

            // held item
            EditorGUILayout.LabelField("Held Item", EditorStyles.boldLabel);
            pickup.heldItem = (Item)EditorGUILayout.ObjectField(pickup.heldItem, typeof(Item), true, GUILayout.MaxWidth(200));

            // pickup settings
            EditorGUILayout.LabelField("Pickup Settings", EditorStyles.boldLabel);

            // cooldown
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Cooldown Time: ", GUILayout.MaxWidth(120));
            pickup.pickupCooldownTime = EditorGUILayout.FloatField(pickup.pickupCooldownTime, GUILayout.MaxWidth(75));
            EditorGUILayout.EndHorizontal();

            // drop distance
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Max Drop Distance: ", GUILayout.MaxWidth(120));
            pickup.maxDropDistance = EditorGUILayout.FloatField(pickup.maxDropDistance, GUILayout.MaxWidth(75));
            EditorGUILayout.EndHorizontal();

            pickup.showOtherGUI = EditorGUILayout.Foldout(pickup.showOtherGUI, "Other");

            if (pickup.showOtherGUI)
                base.OnInspectorGUI();
        }
    }
#endif

    private bool showOtherGUI;

    [HideInInspector] public Item heldItem;

    float pickupCooldownTime = 0.2f, maxDropDistance = 3f;


    [SerializeField] LayerMask dropAbleOn = (1 << 9);

    [SerializeField] ItemShower heldItemShower;
    [SerializeField] GameObject objectOnGround;


    private ItemShower itemOnGroundShower;
    private Cooldown pickupCooldown = new();

    private void Awake()
    {
        if (heldItemShower == null)
            heldItemShower = GetComponentInChildren<ItemShower>();

        if (heldItem != null)
            heldItemShower.item = heldItem;
    }

    private void Start()
    {
        pickupCooldown.SetDuration(pickupCooldownTime);
    }

    public void DropItem()
    {
        if (heldItem == null) return;

        pickupCooldown.StartCoolDown(); // pickup cooldown


        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
        {
            Vector3 dropPosition = hit.point;

            GameObject itemShower = Instantiate(objectOnGround, dropPosition, Quaternion.identity); // create itemshower on ground

            itemShower.GetComponent<ItemShower>().ChangeObject(heldItem); // set item in itemshower to held 
            itemShower.transform.rotation = transform.rotation; // rotate itemshower to player rotation

            // remove held item
            heldItem = null;
            heldItemShower.ChangeObject(null);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        itemOnGroundShower = other.GetComponent<ItemShower>(); // get script

        if (!pickupCooldown.HasEnded) return;

        pickupCooldown.StartCoolDown(); // pickup cooldown

        // change held item
        Item newItemOnGround = heldItem;
        heldItem = itemOnGroundShower.item;

        itemOnGroundShower.ChangeObject(newItemOnGround); // change item on ground to held item
        itemOnGroundShower.transform.rotation = transform.rotation; // rotate item on ground with character

        // if no item in hand destroy itemOnGroundObject
        if (newItemOnGround == null)
            Destroy(itemOnGroundShower.gameObject);

        heldItemShower.ChangeObject(heldItem); // change item in hand to item on ground
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(heldItemShower.transform.position, heldItemShower.transform.position + maxDropDistance * Vector3.down);

        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
            Gizmos.DrawWireSphere(hit.point, 0.5f);
    }
}