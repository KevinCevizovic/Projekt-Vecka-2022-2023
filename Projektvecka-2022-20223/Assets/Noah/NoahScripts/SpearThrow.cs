using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpearThrow : MonoBehaviour
{
    public GameObject parentSpear;
    public Rigidbody rb;

    public float throwSpeed;

    private void Start()
    {
        transform.parent = parentSpear.transform;
        rb.useGravity = false;
    }

    public void Release()
    {
        transform.parent = null;

        rb.useGravity = true;
        transform.rotation = parentSpear.transform.rotation;
        rb.AddForce(transform.forward * throwSpeed);
    }
}
