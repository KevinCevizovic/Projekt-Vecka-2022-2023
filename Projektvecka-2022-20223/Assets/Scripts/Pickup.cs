using UnityEngine;

public class Pickup : MonoBehaviour
{
    public Item heldItem;

    [SerializeField] float pickupCooldown = 0.2f, maxDropDistance = 3f;

    [SerializeField] ItemShower heldItemShower;
    [SerializeField] GameObject objectOnGround;

    [SerializeField] LayerMask dropAbleOn = (1 << 9);

    private ItemShower itemOnGroundShower;

    bool pickupOnCooldown = false;

    private void Awake()
    {
        if (heldItemShower == null)
            heldItemShower = GetComponentInChildren<ItemShower>();

        if (heldItem != null)
            heldItemShower.item = heldItem;
    }

    public void DropItem()
    {
        if (heldItem == null) return;

        // cooldown
        pickupOnCooldown = true;
        Invoke(nameof(resetPickupCooldown), pickupCooldown);

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

    private void resetPickupCooldown() => pickupOnCooldown = false;

    private void OnTriggerEnter(Collider other)
    {
        itemOnGroundShower = other.GetComponent<ItemShower>(); // get script

        //if (itemOnGroundShower.item.collectible) return;


        if (pickupOnCooldown) return;

        // cooldown
        pickupOnCooldown = true;
        Invoke(nameof(resetPickupCooldown), pickupCooldown);

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