using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCommunication : MonoBehaviour
{
    [SerializeField] InputHandler _input;
    [SerializeField] private LayerMask myMask;
    [Range(0, 50f)]
    [SerializeField] private float callingRange;
    private void Awake()
    {
        if (_input == null)
            _input = GetComponent<InputHandler>();
    }

    public void Communicate()
    {
        Collider[] teamates = Physics.OverlapSphere(transform.position, callingRange, myMask);
        foreach (Collider teamate in teamates)
        {
            teamate.GetComponent<EnemyAI>().currentState = EnemyAI.States.FollowingPlayer;
        }
    }
}
