using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Market : MonoBehaviour
{
    Wallet wallet;

    private void Awake()
    {
        wallet = GameObject.FindGameObjectWithTag("Player").GetComponent<Wallet>();
    }

    private void OnTriggerEnter(Collider other)
    {
        
    }
}
