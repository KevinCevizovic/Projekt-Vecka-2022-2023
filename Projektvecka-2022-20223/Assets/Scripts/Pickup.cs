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
    private ItemShower itemShowerOnGround; // if player is standing on a item this is a refrence to that

    [Header("Other")]
    [SerializeField] private GameObject objectOnGroundPrefab;
    [SerializeField] private ItemShower heldItemShower;

    private Cooldown pickupCooldown = new();
    private PickupCanvasScript canvasScript;

    private void Awake()
    {
        if (heldItemShower == null)
            heldItemShower = GetComponentInChildren<ItemShower>();

        heldItemShower.ChangeObject(heldItem); // this shouldnt have a null check, cant be set in start

        canvasScript = FindObjectOfType<PickupCanvasScript>();
        if (canvasScript == null)
            Debug.Log("No pickup canvas");

        if (objectOnGroundPrefab == null)
            objectOnGroundPrefab = Resources.Load("ObjectOnGround") as GameObject;
    }

    private void Start()
    {
        pickupCooldown.SetDuration(pickupCooldownTime);

        if (canvasScript != null)
            canvasScript.Hide();
    }

    /// <summary> Drops item </summary>
    public void DropItem(Item item)
    {
        if (item == null) return;

        Debug.Log("Droped " + item.Name);

        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
        {
            Vector3 dropPosition = hit.point;

            GameObject itemShower = Instantiate(objectOnGroundPrefab, dropPosition, Quaternion.identity); // create itemshower on ground

            itemShower.GetComponent<ItemShower>().ChangeObject(item, !keepColliderOnDrop); // set item in itemshower to held 
            itemShower.transform.rotation = transform.rotation; // rotate itemshower to player rotation
        }
    }

    /// <summary> Picks up item from itemShower and returns it </summary>
    private Item PickupItem(ItemShower itemShower)
    {
        if (itemShower == null) return null;

        Debug.Log("Picked up " + itemShower.Item.Name);

        Item pickedupItem = itemShower.Item;

        Destroy(itemShower.gameObject);

        return pickedupItem;
    }

    /// <summary> Swaps itemShowers item with item and returns itemShowers item </summary>
    private Item SwapItem(ItemShower itemShower, Item item)
    {
        if (itemShower == null || item == null) return null;

        Debug.Log($"Swaped {itemShower.Item.Name} and {item.Name}");

        var itemShowersItem = itemShower.Item;
        itemShower.ChangeObject(item);

        return itemShowersItem;
    }

    public void PickupInput(InputAction.CallbackContext ctx)
    {
        // swap
        if (ctx.started && itemShowerOnGround != null && heldItem != null && pickupCooldown.HasEnded)
        {
            heldItem = SwapItem(itemShowerOnGround, heldItem); // like doing pickup and drop but without creating and deleting objects

            return;
        }

        // pickup
        if (ctx.started && itemShowerOnGround != null && pickupCooldown.HasEnded)
        {
            pickupCooldown.StartCoolDown(); // pickup cooldown

            heldItem = PickupItem(itemShowerOnGround);
            heldItemShower.ChangeObject(heldItem);

            if (canvasScript != null)
                canvasScript.Hide();

            return;
        }

        // drop
        if (ctx.started && heldItem != null)
        {
            pickupCooldown.StartCoolDown(); // pickup cooldown

            DropItem(heldItem);

            // remove held item
            heldItem = null;
            heldItemShower.ChangeObject(null);

            return; // useless return
        }
    }

    private void CollectCollectible(ItemShower itemShower)
    {
        Item item = itemShower.Item;

        Debug.Log($"{item.GetType()} collected");

        ((Collectible)item).Collected(gameObject);
        Destroy(itemShower.gameObject);
    }

    private void OnTriggerEnter(Collider other)
    {
        // checks if its a itemshower
        if (!other.TryGetComponent(out ItemShower itemOnGroundShower)) return;

        itemShowerOnGround = itemOnGroundShower;

        Item item = itemOnGroundShower.Item;

        if (item.GetType().BaseType == typeof(Collectible)) // checks if its a collectible
        {
            CollectCollectible(itemOnGroundShower);
            return;
        }
        else // not a collectible
        {
            if (canvasScript != null && item != null)
            {
                canvasScript.ChangeText($"Press E to pickup {item.Name}");
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

    private void OnDrawGizmos()
    {
        if (heldItemShower == null) return;

        Gizmos.color = Color.red;
        Gizmos.DrawLine(heldItemShower.transform.position, heldItemShower.transform.position + maxDropDistance * Vector3.down);

        if (Physics.Raycast(heldItemShower.transform.position, Vector3.down, out var hit, maxDropDistance, dropAbleOn))
            Gizmos.DrawWireSphere(hit.point, 0.5f);
    }
}