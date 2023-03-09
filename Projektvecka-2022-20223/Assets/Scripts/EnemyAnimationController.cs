using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAnimationController : MonoBehaviour
{
    Animator anim;
    EnemyAI ai;
    // Start is called before the first frame update
    void Awake()
    {
        ai = GetComponent<EnemyAI>();
        anim = GetComponentInChildren<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if(ai.currentState == EnemyAI.States.FollowingPlayer)
        {
            anim.SetInteger("State", 0);
        }
        if (ai.currentState == EnemyAI.States.Avoiding)
        {
            anim.SetInteger("State", 1);
        }
        if (ai.currentState == EnemyAI.States.Chasing)
        {
            anim.SetInteger("State", 0);
        }
        if (ai.currentState == EnemyAI.States.GoingHome)
        {
            anim.SetInteger("State", 0);
        }
        if (ai.currentState == EnemyAI.States.Hitting)
        {
            anim.SetInteger("State", 2);
        }
        if (ai.currentState == EnemyAI.States.Shooting)
        {
            anim.SetInteger("State", 3);
        }
    }
}
