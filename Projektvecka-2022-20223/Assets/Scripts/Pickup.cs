using UnityEngine;
using UnityEngine.InputSystem;

public class Pickup : MonoBehaviour
{
    public Item heldItem;

    [Header("Variables")]
    [SerializeField] private float pickupCooldownTime = 0.2f;
    [SerializeField] private float maxDropDistance = 3f;
    [SerializeField] private bool keepColliderOnDrop = false;
    [SerializeField] private LayerMask dropAbleOn = 1 << 9;
    private ItemShower itemShowerOnGround;

    [Header("Other")]
    [SerializeField] private GameObject objectOnGroundPrefab;
    [SerializeField] private ItemShower heldItemShower;

    private Cooldown pickupCooldown = new();
    private PickupCanvasScript canvasScript;

    private void Awake()
    {
        if (heldItemShower == null)
            heldItemShower = GetComponentInChildren<ItemShower>();

        heldItemShower.item = heldItem; // this shouldnt have a null check, cant be set in start

        canvasScript = FindObjectOfType<PickupCanvasScript>();

        if (canvasScript == null)
            Debug.Log("No pickup canvas or pickup canvas doesnt have script attached");

        if (objectOnGroundPrefab == null)
            objectOnGroundPrefab = Resources.Load("ObjectOnGround") as GameObject;
    }

    private void Start()
    {
        pickupCooldown.SetDuration(pickupCooldownTime);

        canvasScript.Hide();
    }

    /// <summary> Drops HeldItem </summary>
    public void DropItem()
    {
        if (heldItem == null) return;

        Debug.Log("Drop " + heldItem);

        pickupCooldown.StartCoolDown(); // pickup cooldown

        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
        {
            Vector3 dropPosition = hit.point;

            GameObject itemShower = Instantiate(objectOnGroundPrefab, dropPosition, Quaternion.identity); // create itemshower on ground

            itemShower.GetComponent<ItemShower>().ChangeObject(heldItem, !keepColliderOnDrop); // set item in itemshower to held 
            itemShower.transform.rotation = transform.rotation; // rotate itemshower to player rotation

            // remove held item
            heldItem = null;
            heldItemShower.ChangeObject(null);
        }
    }

    public void PickupInput(InputAction.CallbackContext ctx)
    {
        // pickup
        if (ctx.canceled && itemShowerOnGround != null && pickupCooldown.HasEnded)
        {
            pickupCooldown.StartCoolDown(); // pickup cooldown

            PickupFromGround(itemShowerOnGround);
        }

        // drop
        if (ctx.started && heldItem != null)
            DropItem();
    }

    private void OnTriggerEnter(Collider other)
    {
        // checks if its a itemshower
        if (!other.TryGetComponent(out ItemShower itemOnGroundShower)) return;

        itemShowerOnGround = itemOnGroundShower;

        Item item = itemOnGroundShower.item;

        if (item.GetType().BaseType == typeof(Collectible)) // checks if its a collectible
        {
            Debug.Log($"{item.GetType()} collected");

            ((Collectible)item).Activate(gameObject);
            Destroy(itemOnGroundShower.gameObject);
            return;
        }
        else // not a collectible
        {
            if (canvasScript != null && item != null)
            {
                canvasScript.ChangeText($"Press E to pickup {item.ItemName}");
                canvasScript.ShowAndSetPosition(itemOnGroundShower.transform.position);
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        itemShowerOnGround = null;

        if (canvasScript != null)
            canvasScript.Hide();
    }

    private void PickupFromGround(ItemShower itemOnGroundShower)
    {
        Debug.Log("Pickup " + itemOnGroundShower.item);

        Item newHeldItem = itemOnGroundShower.item;

        // change held item
        Item newItemOnGround = heldItem;
        heldItem = newHeldItem;

        itemOnGroundShower.ChangeObject(newItemOnGround, !keepColliderOnDrop); // change item on ground to held item
        itemOnGroundShower.transform.rotation = transform.rotation; // rotate item on ground with character

        // if no item in hand destroy itemOnGroundObject
        if (newItemOnGround == null)
            Destroy(itemOnGroundShower.gameObject);

        heldItemShower.ChangeObject(newHeldItem);
        itemShowerOnGround = null;

        if (canvasScript != null)
            canvasScript.Hide();
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