using UnityEditor;
using UnityEngine;
using UnityEditorInternal;

public class Pickup : MonoBehaviour
{
#if UNITY_EDITOR
    [CustomEditor(typeof(Pickup))]
    public class PickupEditor : Editor
    {
        private bool showOtherGUI;

        public override void OnInspectorGUI()
        {
            Pickup script = (Pickup)target;

            // held item
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Held item", EditorStyles.boldLabel, GUILayout.MaxWidth(75));
            script.heldItem = (Item)EditorGUILayout.ObjectField(script.heldItem, typeof(ScriptableObject), true, GUILayout.MaxWidth(150));
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();

            // pickup settings
            EditorGUILayout.LabelField("Pickup Settings", EditorStyles.boldLabel);

            // cooldown time
            script.pickupCooldownTime = SlideableFloatFieldWithWidth("Cooldown Time", script.pickupCooldownTime, 120f, 75f);

            // drop distance
            script.maxDropDistance = SlideableFloatFieldWithWidth("Drop Distance", script.maxDropDistance, 120f, 75f);

            // other foldout
            showOtherGUI = EditorGUILayout.Foldout(showOtherGUI, "Other");


            if (showOtherGUI)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Drop able on", EditorStyles.boldLabel, GUILayout.MaxWidth(120));
                LayerMask tempMask = EditorGUILayout.MaskField(InternalEditorUtility.LayerMaskToConcatenatedLayersMask(script.dropAbleOn), InternalEditorUtility.layers, GUILayout.MaxWidth(75));
                script.dropAbleOn = InternalEditorUtility.ConcatenatedLayersMaskToLayerMask(tempMask);
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Held item shower", EditorStyles.boldLabel, GUILayout.MaxWidth(120));
                script.heldItemShower = (ItemShower)EditorGUILayout.ObjectField(script.heldItemShower, typeof(ItemShower), true, GUILayout.MaxWidth(150));
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Object on ground", EditorStyles.boldLabel, GUILayout.MaxWidth(120));
                script.objectOnGroundPrefab = (GameObject)EditorGUILayout.ObjectField(script.objectOnGroundPrefab, typeof(Object), true, GUILayout.MaxWidth(150));
                EditorGUILayout.EndHorizontal();
            }
        }

        private static float SlideableFloatFieldWithWidth(float variable, float labelFieldWidth, float fieldWidth)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("", GUILayout.MaxWidth(labelFieldWidth));
            variable = EditorGUILayout.FloatField(variable, GUILayout.MaxWidth(fieldWidth));
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space(-22);
            variable = EditorGUILayout.FloatField("\n", variable, GUILayout.MaxWidth(-122));

            return variable;
        }

        private static float SlideableFloatFieldWithWidth(string label, float variable, float labelFieldWidth, float fieldWidth)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("", GUILayout.MaxWidth(labelFieldWidth));
            variable = EditorGUILayout.FloatField(variable, GUILayout.MaxWidth(fieldWidth));
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space(-22);
            variable = EditorGUILayout.FloatField(label, variable, GUILayout.MaxWidth(-122));

            return variable;
        }
    }
#endif

    public Item heldItem;

    [SerializeField] float pickupCooldownTime = 0.2f, maxDropDistance = 3f;


    [SerializeField] LayerMask dropAbleOn = 1 << 9;

    [SerializeField] ItemShower heldItemShower;
    [SerializeField] GameObject objectOnGroundPrefab;


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

    /// <summary> Drops HeldItem </summary>
    public void DropItem()
    {
        if (heldItem == null) return;

        pickupCooldown.StartCoolDown(); // pickup cooldown


        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
        {
            Vector3 dropPosition = hit.point;

            GameObject itemShower = Instantiate(objectOnGroundPrefab, dropPosition, Quaternion.identity); // create itemshower on ground

            itemShower.GetComponent<ItemShower>().ChangeObject(heldItem, true); // set item in itemshower to held 
            itemShower.transform.rotation = transform.rotation; // rotate itemshower to player rotation

            // remove held item
            heldItem = null;
            heldItemShower.ChangeObject(null);
        }
    }

    public void DropItem(Item item)
    {
        pickupCooldown.StartCoolDown(); // pickup cooldown

        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
        {
            Vector3 dropPosition = hit.point;

            GameObject itemShower = Instantiate(objectOnGroundPrefab, dropPosition, Quaternion.identity); // create itemshower on ground

            itemShower.GetComponent<ItemShower>().ChangeObject(item, true); // set item in itemshower to held 
            itemShower.transform.rotation = transform.rotation; // rotate itemshower to player rotation
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        // checks if its a itemshower
        if (!other.TryGetComponent(out ItemShower itemOnGroundShower)) return;

        Item item = itemOnGroundShower.item;

        if (item.GetType().BaseType == typeof(Collectible))
        {
            Debug.Log($"{item.GetType()} collected");

            ((Collectible)item).Activate(gameObject);
            Destroy(itemOnGroundShower.gameObject);
            return;
        }


        if (!pickupCooldown.HasEnded) return;

        pickupCooldown.StartCoolDown(); // pickup cooldown

        // change held item
        Item newItemOnGround = heldItem;
        heldItem = item;

        itemOnGroundShower.ChangeObject(newItemOnGround, true); // change item on ground to held item
        itemOnGroundShower.transform.rotation = transform.rotation; // rotate item on ground with character

        // if no item in hand destroy itemOnGroundObject
        if (newItemOnGround == null)
            Destroy(itemOnGroundShower.gameObject);

        heldItemShower.ChangeObject(heldItem); // change item in hand to item on ground
    }

    private void OnDrawGizmos()
    {
        if (heldItemShower == null) return;

        Gizmos.color = Color.red;
        Gizmos.DrawLine(heldItemShower.transform.position, heldItemShower.transform.position + maxDropDistance * Vector3.down);

        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
            Gizmos.DrawWireSphere(hit.point, 0.5f);
    }
}