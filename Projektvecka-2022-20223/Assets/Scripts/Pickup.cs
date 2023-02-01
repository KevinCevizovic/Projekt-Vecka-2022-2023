using UnityEngine;

public class Pickup : MonoBehaviour
{
    // health potion
    // coins

    // weapons
    //public Weapon heldWeapon;

    public Item heldItem;
    private ItemShower itemOnGroundObject;
    [SerializeField] ItemShower handItem;
    [SerializeField] GameObject objectOnGround;

    public LayerMask dropAbleOn;
    public float distance = 0.5f;


    private void Awake()
    {
        handItem.item = heldItem;
    }

    public void DropItem()
    {
        if (heldItem is null) return;

        RaycastHit hit;
        if (Physics.Raycast(handItem.transform.position, Vector3.down, out hit, Mathf.Infinity, dropAbleOn))
        {
            Vector3 dropPosition = hit.point + Vector3.up * distance;

            GameObject itemShower = Instantiate(objectOnGround, dropPosition, Quaternion.identity);
            itemShower.GetComponent<ItemShower>().ChangeObject(heldItem);

            heldItem = null;
            handItem.ChangeObject(null);
        }
        //Debug.Log(hit.collider);
    }

    private void OnTriggerEnter(Collider other)
    {
        itemOnGroundObject = other.GetComponent<ItemShower>(); // get script

        // change held item
        Item lastHeldItem = heldItem;
        heldItem = itemOnGroundObject.item;

        itemOnGroundObject.ChangeObject(lastHeldItem); // change item on ground to held item

        // if no item in hand destroy itemOnGroundObject
        if (lastHeldItem == null)
            Destroy(itemOnGroundObject.gameObject);

        handItem.ChangeObject(heldItem); // change item in hand to item on ground
    }
}