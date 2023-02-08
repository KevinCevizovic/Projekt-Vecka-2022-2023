using UnityEngine;
using System;

public class PlayerCommunication : MonoBehaviour
{
    [SerializeField] private LayerMask teamateLayer;
    [Range(0, 50f)]
    [SerializeField] private float callingRange;
    [SerializeField] private bool isFollowing = false;
    [SerializeField] Collider[] teamates;

    public void Communicate()
    {
        isFollowing = !isFollowing;
        teamates = Physics.OverlapSphere(transform.position, callingRange, teamateLayer);
        foreach (Collider teamate in teamates)
            teamate.GetComponent<EnemyAI>().currentState = EnemyAI.States.FollowingPlayer;
    }

    private void Update()
    {
        if (!isFollowing)
        {
            try
            {
                foreach (Collider teamate in teamates)
                    teamate.GetComponent<EnemyAI>().currentState = EnemyAI.States.IdleWalking;
            }
            catch
            {
                
            }
            
        }
        try
        {
            Array.Clear(teamates, 0, teamates.Length);
        }
        catch
        {

        }
    }
}