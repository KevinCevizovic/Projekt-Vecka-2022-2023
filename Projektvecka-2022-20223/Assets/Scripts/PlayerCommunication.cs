using UnityEngine;

public class PlayerCommunication : MonoBehaviour
{
    [SerializeField] private LayerMask teamateLayer;
    [Range(0, 50f)]
    [SerializeField] private float callingRange;
    public void Communicate()
    {
        Collider[] teamates = Physics.OverlapSphere(transform.position, callingRange, teamateLayer);
        foreach (Collider teamate in teamates)
            teamate.GetComponent<EnemyAI>().currentState = EnemyAI.States.FollowingPlayer;
    }
}